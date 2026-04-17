import { isCustomModel, toCustomModelId } from '../../common/src/constants/custom-model';

test('nvidia‑llama agent uses the custom provider', () => {
  const model = 'custom/meta/llama-3.1-405b-instruct';
  expect(isCustomModel(model)).toBe(true);
  expect(toCustomModelId(model)).toBe('meta/llama-3.1-405b-instruct');
});
