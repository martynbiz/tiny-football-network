import rpcHealthcheck from '../src/healthcheck';
import {describe, expect, test} from '@jest/globals'

describe('testing index file', () => {
  test('empty string should result in zero', () => {
    const result = JSON.parse(rpcHealthcheck(null, null, null, null))
    expect(result.success).toBe(true);
  });
});