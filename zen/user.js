// Reopen the previous session, including pinned and regular tabs.
user_pref("browser.startup.page", 3);

// Recover the session after a crash and restore separate, unsynced windows too.
user_pref("browser.sessionstore.resume_from_crash", true);
user_pref("zen.session-store.restore-unsynced-windows", true);
