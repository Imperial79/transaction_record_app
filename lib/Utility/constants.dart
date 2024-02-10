String getUsername({required String email}) {
  return email.split("@").first;
}
