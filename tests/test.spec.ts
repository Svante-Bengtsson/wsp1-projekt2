import { test, expect } from '@playwright/test';

const BASE_URL = 'http://localhost:9292';
const TEST_USER = 'test';
const TEST_PASS = 'test';

test('basic test', async ({ page }) => {
  await page.goto('http://localhost:9292');
  await expect(page).toHaveURL(/\/games/);
});


test('register, login, add game, strat and tag, and then delete game', async ({ page }) => {
  // Register
  await page.goto(`${BASE_URL}/register`);
  await page.fill('input[name="name"]', TEST_USER);
  await page.fill('input[name="password"]', TEST_PASS);
  await page.click('button[type="submit"], input[type="submit"]');

  // Login
  await page.goto(`${BASE_URL}/login`);
  await page.fill('input[name="name"]', TEST_USER);
  await page.fill('input[name="password"]', TEST_PASS);
  await page.click('button[type="submit"], input[type="submit"]');

  await expect(page).toHaveURL(`${BASE_URL}/games`);

  // Add a game
  await page.goto(`${BASE_URL}/games`);
  await page.fill('input[name="game_name"]', 'Test Game');
  await page.fill('input[name="game_description"]', 'Test game description');
  await page.click('input[type="submit"]')

  // Check game was created and we were redirected
  await expect(page.locator('h2', { hasText: 'Name: Test Game' })).toBeVisible();

  // Add a strat to the game
  await page.fill('input[name="strat_name"]', 'Test Strat');
  await page.fill('input[name="strat_description"]', 'This is a test strat.');
  await page.click('input[type="submit"][value="lägg till"]');

  // Check strat was created
  await expect(page.locator('body')).toContainText('Test Strat');

  // Go to add a tag
  await page.locator('a', { hasText: 'lägg till tag!' }).click();

  // Add a new tag
  await page.fill('input[name="tag_name"]', 'Test tag');
  await page.fill('input[name="tag_description"]', 'This is a test tag.');
  await page.click('input[type="submit"][value="lägg till"]');

  // Add tag to game
  await page.click('input[type="submit"][value="Test tag"]');

  // Navigate back to game and check that the tag is there
  await page.locator('a', { hasText: '< tillbaka' }).click();
  await expect(page.locator('body')).toContainText('Test tag');

  // log into admin and delete test-game
  await page.locator('a', { hasText: 'logga ut' }).click();
  await page.goto(`${BASE_URL}/login`);
  await page.fill('input[name="name"]', 'admin');
  await page.fill('input[name="password"]', '123');
  await page.click('input[type="submit"]');
  await page.click('text=Test Game');
  await page.click('button:has-text("Radera spel")');
});