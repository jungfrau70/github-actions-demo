// Day3 - Production Level Application with Advanced Monitoring
// Cloud Master Day3 강의안 기반

const express = require('express');
const { createClient } = require('redis');
const { Pool } = require('pg');
const client = require('prom-client');
const opentelemetry = require('@opentelemetry/api');
const { NodeTracerProvider } = require('@opentelemetry/sdk-trace-node');
const { Resource } = require('@opentelemetry/resources');
const { SemanticResourceAttributes } = require('@opentelemetry/semantic-conventions');
const { JaegerExporter } = require('@opentelemetry/exporter-jaeger');
const { registerInstrumentations } = require('@opentelemetry/instrumentations');
const { ExpressInstrumentation } = require('@opentelemetry/instrumentation-express');
const { HttpInstrumentation } = require('@opentelemetry/instrumentation-http');
const { PgInstrumentation } = require('@opentelemetry/instrumentation-pg');
const { RedisInstrumentation } = require('@opentelemetry/instrumentation-redis');

const app = express();
const PORT = process.env.PORT || 3000;

// OpenTelemetry 설정
const tracerProvider = new NodeTracerProvider({
  resource: new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: 'github-actions-demo',
    [SemanticResourceAttributes.SERVICE_VERSION]: '3.0.0',
  }),
});

const jaegerExporter = new JaegerExporter({
  endpoint: process.env.JAEGER_ENDPOINT || 'http://jaeger:14268/api/traces',
});

tracerProvider.addSpanProcessor(new jaegerExporter);
tracerProvider.register();

registerInstrumentations({
  instrumentations: [
    new ExpressInstrumentation(),
    new HttpInstrumentation(),
    new PgInstrumentation(),
    new RedisInstrumentation(),
  ],
});

const tracer = opentelemetry.trace.getTracer('github-actions-demo');

// Prometheus 메트릭 설정
const register = new client.Registry();
client.collectDefaultMetrics({ register });

// 커스텀 메트릭
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code', 'service'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});

const httpRequestTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code', 'service']
});

const activeConnections = new client.Gauge({
  name: 'active_connections',
  help: 'Number of active connections'
});

const databaseConnections = new client.Gauge({
  name: 'database_connections_active',
  help: 'Number of active database connections'
});

const redisConnections = new client.Gauge({
  name: 'redis_connections_active',
  help: 'Number of active Redis connections'
});

const errorRate = new client.Counter({
  name: 'errors_total',
  help: 'Total number of errors',
  labelNames: ['type', 'service']
});

const businessMetrics = new client.Counter({
  name: 'business_operations_total',
  help: 'Total number of business operations',
  labelNames: ['operation', 'status']
});

register.registerMetric(httpRequestDuration);
register.registerMetric(httpRequestTotal);
register.registerMetric(activeConnections);
register.registerMetric(databaseConnections);
register.registerMetric(redisConnections);
register.registerMetric(errorRate);
register.registerMetric(businessMetrics);

// Redis 클라이언트 설정
let redisClient;
if (process.env.REDIS_URL) {
  redisClient = createClient({
    url: process.env.REDIS_URL,
    retry_strategy: (options) => {
      if (options.error && options.error.code === 'ECONNREFUSED') {
        return new Error('Redis server refused connection');
      }
      if (options.total_retry_time > 1000 * 60 * 60) {
        return new Error('Retry time exhausted');
      }
      if (options.attempt > 10) {
        return undefined;
      }
      return Math.min(options.attempt * 100, 3000);
    }
  });
  
  redisClient.on('error', (err) => {
    console.error('Redis Client Error:', err);
    errorRate.inc({ type: 'redis_connection', service: 'web' });
  });
  
  redisClient.on('connect', () => {
    console.log('Redis connected successfully');
  });
  
  redisClient.connect().catch(console.error);
}

// PostgreSQL 클라이언트 설정
let pool;
if (process.env.DATABASE_URL) {
  pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
  });
  
  pool.on('error', (err) => {
    console.error('PostgreSQL pool error:', err);
    errorRate.inc({ type: 'database_connection', service: 'web' });
  });
}

// 미들웨어
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(express.static('public'));

// 요청 시간 측정 미들웨어
app.use((req, res, next) => {
  const start = Date.now();
  const span = tracer.startSpan(`${req.method} ${req.path}`);
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const labels = {
      method: req.method,
      route: req.route ? req.route.path : req.path,
      status_code: res.statusCode,
      service: 'web'
    };
    
    httpRequestDuration.observe(labels, duration);
    httpRequestTotal.inc(labels);
    
    span.setAttributes({
      'http.method': req.method,
      'http.url': req.url,
      'http.status_code': res.statusCode,
      'http.response_time': duration
    });
    
    span.end();
  });
  
  next();
});

// 연결 수 추적
let connectionCount = 0;
app.use((req, res, next) => {
  connectionCount++;
  activeConnections.set(connectionCount);
  
  res.on('close', () => {
    connectionCount--;
    activeConnections.set(connectionCount);
  });
  
  next();
});

// 데이터베이스 연결 수 추적
setInterval(() => {
  if (pool) {
    databaseConnections.set(pool.totalCount);
  }
  if (redisClient && redisClient.isOpen) {
    redisConnections.set(1);
  }
}, 5000);

// 기본 라우트
app.get('/', async (req, res) => {
  const span = tracer.startSpan('home_route');
  
  try {
    const info = {
      message: 'Cloud Master Day3 - Production Level Operations',
      version: '3.0.0',
      environment: process.env.NODE_ENV || 'development',
      timestamp: new Date().toISOString(),
      features: [
        'Production Express Server',
        'Advanced Database Integration',
        'Redis Caching & Session Management',
        'Comprehensive Monitoring (Prometheus, Grafana)',
        'Distributed Tracing (Jaeger)',
        'Log Aggregation (ELK Stack)',
        'Load Balancing & Auto Scaling',
        'Security Scanning & Compliance',
        'Cost Optimization',
        'High Availability Architecture'
      ],
      metrics: {
        active_connections: connectionCount,
        uptime: process.uptime(),
        memory_usage: process.memoryUsage(),
        cpu_usage: process.cpuUsage()
      }
    };
    
    // Redis 캐싱
    if (redisClient && redisClient.isOpen) {
      await redisClient.setEx('home_info', 300, JSON.stringify(info));
    }
    
    businessMetrics.inc({ operation: 'home_page_view', status: 'success' });
    
    span.setStatus({ code: 1, message: 'Success' });
    res.json(info);
  } catch (error) {
    console.error('Error in home route:', error);
    errorRate.inc({ type: 'application_error', service: 'web' });
    businessMetrics.inc({ operation: 'home_page_view', status: 'error' });
    
    span.setStatus({ code: 2, message: error.message });
    res.status(500).json({ error: 'Internal server error' });
  } finally {
    span.end();
  }
});

// 헬스 체크 엔드포인트
app.get('/health', async (req, res) => {
  const span = tracer.startSpan('health_check');
  
  try {
    const health = {
      status: 'healthy',
      uptime: process.uptime(),
      timestamp: new Date().toISOString(),
      services: {},
      metrics: {
        active_connections: connectionCount,
        memory_usage: process.memoryUsage(),
        cpu_usage: process.cpuUsage()
      }
    };
    
    // 데이터베이스 상태 확인
    if (pool) {
      try {
        const start = Date.now();
        await pool.query('SELECT 1');
        const duration = Date.now() - start;
        
        health.services.database = {
          status: 'healthy',
          response_time: duration
        };
      } catch (error) {
        health.services.database = {
          status: 'unhealthy',
          error: error.message
        };
        health.status = 'unhealthy';
        errorRate.inc({ type: 'database_health_check', service: 'web' });
      }
    }
    
    // Redis 상태 확인
    if (redisClient && redisClient.isOpen) {
      try {
        const start = Date.now();
        await redisClient.ping();
        const duration = Date.now() - start;
        
        health.services.redis = {
          status: 'healthy',
          response_time: duration
        };
      } catch (error) {
        health.services.redis = {
          status: 'unhealthy',
          error: error.message
        };
        health.status = 'unhealthy';
        errorRate.inc({ type: 'redis_health_check', service: 'web' });
      }
    }
    
    businessMetrics.inc({ operation: 'health_check', status: health.status });
    
    span.setStatus({ code: 1, message: 'Health check completed' });
    res.status(health.status === 'healthy' ? 200 : 503).json(health);
  } catch (error) {
    console.error('Error in health check:', error);
    errorRate.inc({ type: 'health_check_error', service: 'web' });
    
    span.setStatus({ code: 2, message: error.message });
    res.status(500).json({ error: 'Health check failed' });
  } finally {
    span.end();
  }
});

// 메트릭 엔드포인트
app.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  } catch (error) {
    console.error('Error in metrics endpoint:', error);
    res.status(500).json({ error: 'Metrics collection failed' });
  }
});

// API 엔드포인트
app.get('/api/info', async (req, res) => {
  const span = tracer.startSpan('api_info');
  
  try {
    const info = {
      service: 'github-actions-demo',
      day: 3,
      features: [
        'Production-grade Express Server',
        'Multi-stage Docker Build',
        'Docker Compose Production Stack',
        'Advanced Database Integration',
        'Redis Caching & Session Management',
        'Comprehensive Monitoring Stack',
        'Distributed Tracing',
        'Log Aggregation & Analysis',
        'Load Balancing & Auto Scaling',
        'Security Scanning & Compliance',
        'Cost Optimization',
        'High Availability Architecture',
        'Blue-Green Deployment',
        'Chaos Engineering',
        'Performance Testing'
      ],
      metrics: {
        active_connections: connectionCount,
        uptime: process.uptime(),
        memory_usage: process.memoryUsage(),
        cpu_usage: process.cpuUsage()
      }
    };
    
    businessMetrics.inc({ operation: 'api_info_request', status: 'success' });
    
    span.setStatus({ code: 1, message: 'Success' });
    res.json(info);
  } catch (error) {
    console.error('Error in API info route:', error);
    errorRate.inc({ type: 'api_error', service: 'web' });
    businessMetrics.inc({ operation: 'api_info_request', status: 'error' });
    
    span.setStatus({ code: 2, message: error.message });
    res.status(500).json({ error: 'Internal server error' });
  } finally {
    span.end();
  }
});

// 데이터베이스 테스트 엔드포인트
app.get('/api/db/test', async (req, res) => {
  const span = tracer.startSpan('database_test');
  
  if (!pool) {
    span.setStatus({ code: 2, message: 'Database not configured' });
    return res.status(503).json({ error: 'Database not configured' });
  }
  
  try {
    const start = Date.now();
    const result = await pool.query('SELECT NOW() as current_time, version() as postgres_version');
    const duration = Date.now() - start;
    
    businessMetrics.inc({ operation: 'database_test', status: 'success' });
    
    span.setAttributes({
      'db.operation': 'SELECT',
      'db.response_time': duration
    });
    span.setStatus({ code: 1, message: 'Success' });
    
    res.json({
      status: 'success',
      data: result.rows[0],
      response_time: duration
    });
  } catch (error) {
    console.error('Database test error:', error);
    errorRate.inc({ type: 'database_test_error', service: 'web' });
    businessMetrics.inc({ operation: 'database_test', status: 'error' });
    
    span.setStatus({ code: 2, message: error.message });
    res.status(500).json({ error: 'Database connection failed' });
  } finally {
    span.end();
  }
});

// Redis 테스트 엔드포인트
app.get('/api/redis/test', async (req, res) => {
  const span = tracer.startSpan('redis_test');
  
  if (!redisClient || !redisClient.isOpen) {
    span.setStatus({ code: 2, message: 'Redis not configured' });
    return res.status(503).json({ error: 'Redis not configured' });
  }
  
  try {
    const testKey = 'test:' + Date.now();
    const testValue = 'test_value_' + Math.random();
    
    const start = Date.now();
    await redisClient.setEx(testKey, 60, testValue);
    const retrievedValue = await redisClient.get(testKey);
    await redisClient.del(testKey);
    const duration = Date.now() - start;
    
    businessMetrics.inc({ operation: 'redis_test', status: 'success' });
    
    span.setAttributes({
      'redis.operation': 'SET/GET',
      'redis.response_time': duration
    });
    span.setStatus({ code: 1, message: 'Success' });
    
    res.json({
      status: 'success',
      data: {
        test_key: testKey,
        test_value: testValue,
        retrieved_value: retrievedValue,
        match: testValue === retrievedValue,
        response_time: duration
      }
    });
  } catch (error) {
    console.error('Redis test error:', error);
    errorRate.inc({ type: 'redis_test_error', service: 'web' });
    businessMetrics.inc({ operation: 'redis_test', status: 'error' });
    
    span.setStatus({ code: 2, message: error.message });
    res.status(500).json({ error: 'Redis operation failed' });
  } finally {
    span.end();
  }
});

// 비즈니스 로직 엔드포인트
app.get('/api/users', async (req, res) => {
  const span = tracer.startSpan('get_users');
  
  if (!pool) {
    span.setStatus({ code: 2, message: 'Database not configured' });
    return res.status(503).json({ error: 'Database not configured' });
  }
  
  try {
    const start = Date.now();
    const result = await pool.query('SELECT id, username, email, created_at FROM users ORDER BY created_at DESC LIMIT 100');
    const duration = Date.now() - start;
    
    businessMetrics.inc({ operation: 'get_users', status: 'success' });
    
    span.setAttributes({
      'db.operation': 'SELECT',
      'db.table': 'users',
      'db.response_time': duration,
      'db.rows_returned': result.rows.length
    });
    span.setStatus({ code: 1, message: 'Success' });
    
    res.json({
      status: 'success',
      data: result.rows,
      count: result.rows.length,
      response_time: duration
    });
  } catch (error) {
    console.error('Get users error:', error);
    errorRate.inc({ type: 'get_users_error', service: 'web' });
    businessMetrics.inc({ operation: 'get_users', status: 'error' });
    
    span.setStatus({ code: 2, message: error.message });
    res.status(500).json({ error: 'Failed to retrieve users' });
  } finally {
    span.end();
  }
});

// 서버 시작
app.listen(PORT, () => {
  console.log(`🚀 Day3 Production Server running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`📈 Metrics: http://localhost:${PORT}/metrics`);
  console.log(`ℹ️  API info: http://localhost:${PORT}/api/info`);
  console.log(`🗄️  DB test: http://localhost:${PORT}/api/db/test`);
  console.log(`🔴 Redis test: http://localhost:${PORT}/api/redis/test`);
  console.log(`👥 Users API: http://localhost:${PORT}/api/users`);
  console.log(`🔍 Jaeger UI: http://localhost:16686`);
  console.log(`📊 Grafana: http://localhost:3001`);
  console.log(`📈 Prometheus: http://localhost:9090`);
  console.log(`📋 Kibana: http://localhost:5601`);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down gracefully');
  
  if (pool) {
    await pool.end();
  }
  
  if (redisClient && redisClient.isOpen) {
    await redisClient.quit();
  }
  
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('SIGINT received, shutting down gracefully');
  
  if (pool) {
    await pool.end();
  }
  
  if (redisClient && redisClient.isOpen) {
    await redisClient.quit();
  }
  
  process.exit(0);
});

module.exports = app;