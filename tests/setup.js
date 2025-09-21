// 🧪 Jest 테스트 설정
// 테스트 실행 전 공통 설정을 수행합니다

// 테스트 환경 변수 설정
process.env.NODE_ENV = 'test';
process.env.PORT = '0'; // 랜덤 포트 사용

// 테스트 타임아웃 설정
jest.setTimeout(10000);

// 전역 테스트 설정
beforeAll(() => {
  console.log('🧪 테스트 시작');
});

afterAll(() => {
  console.log('✅ 테스트 완료');
});

// 각 테스트 전후 설정
beforeEach(() => {
  // 테스트별 초기화 로직
});

afterEach(() => {
  // 테스트별 정리 로직
});

// 전역 모킹 설정
global.console = {
  ...console,
  // 테스트 중 console.log 억제 (선택사항)
  // log: jest.fn(),
  // warn: jest.fn(),
  // error: jest.fn(),
};
