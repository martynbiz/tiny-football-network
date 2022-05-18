import { testFunc } from '../src/utils';
import { describe, expect, test } from '@jest/globals'

describe('testing index file', () => {
  test('test function', () => {
    const result = JSON.parse(testFunc())
    expect(result.success).toBe(true);
  });
});