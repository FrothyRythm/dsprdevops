const request = require('supertest');
const app = require('../app');

describe('TechNova Application', () => {
  it('should return welcome message', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toEqual(200);
    expect(res.text).toContain('TechNova Solutions');
  });

  it('should show healthy status', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toEqual(200);
    expect(res.body.status).toEqual('healthy');
  });
});