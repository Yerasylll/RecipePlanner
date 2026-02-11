# Release Checklist - Recipe Planner v1.0

## Pre-Release Build

- [ ] Version number set to 1.0 in Info.plist
- [ ] Build number incremented
- [ ] All unit tests passing (10/10)
- [ ] Manual test checklist completed (25/25)
- [ ] No compiler warnings
- [ ] Release configuration uses production Firebase
- [ ] API keys removed from code, using xcconfig

## Security

- [ ] Secrets.xcconfig NOT committed to git
- [ ] GoogleService-Info.plist NOT committed to git
- [ ] Firebase security rules documented
- [ ] No hardcoded credentials in codebase
- [ ] HTTPS only for API calls

## Testing

- [ ] App launches successfully
- [ ] Sign up / Sign in works
- [ ] Offline mode functional
- [ ] Favorites sync with Firebase
- [ ] Comments appear in real-time
- [ ] Rating system working
- [ ] Meal planning calendar works
- [ ] Profile editing functional
- [ ] No crashes on common scenarios
- [ ] Pagination works smoothly
- [ ] Search debouncing works
- [ ] Images load with Kingfisher

## Performance

- [ ] App launch < 2 seconds
- [ ] Recipe feed loads < 3 seconds
- [ ] No memory leaks detected
- [ ] Images cached properly
- [ ] Core Data queries optimized

## Documentation

- [ ] README.md complete with setup instructions
- [ ] ARCHITECTURE.md created with diagrams
- [ ] RELEASE_NOTES.md documents changes
- [ ] Manual test checklist filled out
- [ ] QA_LOG.md documents bug fixes

## Release Build

- [ ] Archive created successfully
- [ ] Build signed for distribution
- [ ] Screenshot of archive saved to docs/