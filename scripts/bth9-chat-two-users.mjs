/**
 * Xac minh chat realtime giua 2 user (2 browser context).
 * Chay: node scripts/bth9-chat-two-users.mjs  (can playwright trong thu muc artifacts hoac NODE_PATH)
 */
import { chromium } from 'playwright';

const BLAZOR = process.env.BLAZOR || 'http://localhost:5081';
const TAG = `chat-${Date.now()}`;

async function login(page, user, password) {
  await page.goto(`${BLAZOR}/login`);
  await page.getByText('User name').locator('..').locator('input').fill(user);
  await page.locator('input[type="password"]').fill(password);
  await page.getByRole('button', { name: 'Sign In' }).click();
  await page.waitForURL(/\/(products|Chat|$)/, { timeout: 15000 }).catch(() => {});
  await page.waitForTimeout(1500);
}

const browser = await chromium.launch({ headless: true });
const ctxA = await browser.newContext();
const ctxB = await browser.newContext();
const pageA = await ctxA.newPage();
const pageB = await ctxB.newPage();

let pass = false;
try {
  await login(pageA, 'jimmy.solid', 'secret');
  await login(pageB, 'danny.solid', 'secret');
  await pageA.goto(`${BLAZOR}/Chat`);
  await pageB.goto(`${BLAZOR}/Chat`);
  await pageA.waitForTimeout(3000);
  await pageB.waitForTimeout(3000);

  const inputA = pageA.locator('.card-body input').first();
  await inputA.fill(TAG);
  await pageA.getByRole('button', { name: /Send/i }).click();
  await pageB.waitForTimeout(4000);

  const bodyB = await pageB.locator('.card-body').innerText();
  pass = bodyB.includes(TAG);
  console.log(pass ? `CHAT_TWO_USER_OK ${TAG}` : `CHAT_TWO_USER_FAIL seen="${bodyB.slice(0, 200)}"`);
  if (!pass) process.exitCode = 1;
} catch (e) {
  console.error('CHAT_TWO_USER_FAIL', e);
  process.exitCode = 1;
} finally {
  await browser.close();
}
