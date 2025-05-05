String getCurrentPageTitle({
  required String selectedPageName,
  required String baseTitle,
}) {
  switch (selectedPageName) {
    case "Home":
      return '$baseTitle - Home Page';
    case "Settings":
      return '$baseTitle - Settings Page';
    case "Logout":
      return '$baseTitle - Logout Confirmation';
    default:
      return baseTitle; // Fallback title
  }
}
