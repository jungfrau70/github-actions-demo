
const express = require('express');
const cors = require('cors');
const client = require('prom-client');
const app = express();
const port = process.env.PORT || 3000;

// Prometheus 메트릭 설정
const register = new client.Registry();
client.collectDefaultMetrics({ register });

// HTTP 요청 메트릭
const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

// 미들웨어 설정 (요청이 들어올 때마다 실행되는 코드)
app.use(cors());           // 다른 도메인에서도 접근 가능하게
app.use(express.json());   // JSON 데이터를 쉽게 처리

// 메트릭 수집 미들웨어
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    httpRequestsTotal
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .inc();
  });
  
  next();
});

// 🏠 홈페이지 - 사용자가 처음 보게 될 화면
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
        <title>GitHub Actions Demo</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            .container { max-width: 800px; margin: 0 auto; }
            .header { color: #333; border-bottom: 2px solid #007acc; padding-bottom: 10px; }
            .info { background: #f5f5f5; padding: 20px; border-radius: 5px; margin: 20px 0; }
            .endpoint { background: #e8f4fd; padding: 10px; margin: 10px 0; border-left: 4px solid #007acc; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1 class="header">🚀 GitHub Actions Demo</h1>
            <div class="info">
                <h2>CI/CD 실습 애플리케이션</h2>
                <p><strong>버전:</strong> 1.0.0</p>
                <p><strong>환경:</strong> ${process.env.NODE_ENV || 'development'}</p>
                <p><strong>시간:</strong> ${new Date().toISOString()}</p>
            </div>
            <div class="endpoint">
                <h3>📊 사용 가능한 엔드포인트:</h3>
                <ul>
                    <li><a href="/health">/health</a> - 헬스 체크</li>
                    <li><a href="/api/status">/api/status</a> - API 상태</li>
                    <li><a href="/metrics">/metrics</a> - Prometheus 메트릭</li>
                </ul>
            </div>
        </div>
    </body>
    </html>
  `);
});

// 🏥 헬스 체크 - 서버가 살아있는지 확인하는 엔드포인트
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    uptime: process.uptime(),        // 서버가 얼마나 오래 실행되었는지
    memory: process.memoryUsage(),   // 메모리 사용량
    timestamp: new Date().toISOString()
  });
});

// 📊 메트릭 엔드포인트 - Prometheus가 사용
app.get('/metrics', (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(register.metrics());
});

// 📊 API 상태 - 개발자나 모니터링 도구가 사용
app.get('/api/status', (req, res) => {
  res.json({
    message: 'API is running',
    service: 'GitHub Actions CI/CD Practice',
    status: 'running',
    version: '1.0.0'
  });
});

// 🚀 서버 시작 (테스트할 때는 제외)
if (process.env.NODE_ENV !== 'test') {
  app.listen(port, () => {
    console.log(`🚀 서버가 포트 ${port}에서 실행 중입니다.`);
    console.log(`📊 헬스 체크: http://localhost:${port}/health`);
  });
}

module.exports = app;  // 테스트할 때 사용할 수 있도록 내보내기