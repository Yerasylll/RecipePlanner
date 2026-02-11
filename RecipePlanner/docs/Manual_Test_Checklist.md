# Manual Test Checklist - Recipe Planner

## Authentication Tests

- [ ] **Test 1:** Sign up with new account (valid email + password ≥6 chars)
  - Expected: Account created, auto-login to home screen

- [ ] **Test 2:** Sign up with invalid email format
  - Expected: Error message "Invalid email format"

- [ ] **Test 3:** Sign in with wrong password
  - Expected: Error message displayed, no crash

## Recipe Browsing Tests

- [ ] **Test 4:** Load recipe feed with internet connection
  - Expected: 20 recipes load, images appear, pagination works

## Offline Mode Tests

- [ ] **Test 5:** Turn off WiFi/airplane mode, open app
  - Expected: Cached recipes display, "No internet" message if trying to load new data


## Favorites Tests

- [ ] **Test 6:** Tap heart icon on recipe to favorite
  - Expected: Heart fills red, recipe appears in Favorites tab


## Comments (Realtime) Tests

- [ ] **Test 7:** Add comment to recipe
  - Expected: Comment appears immediately at top of list

## Rating Tests

- [ ] **Test 8:** Rate recipe with 5 stars and review text
  - Expected: Rating submitted, average rating updates on detail page


## Profile Tests

- [ ] **Test 9:** Edit username in profile
  - Expected: Username updates, visible in profile and future comments


## Edge Cases

- [ ] **Test 10:** Rapid tap on recipe cards
  - Expected: No crashes, detail page loads once
