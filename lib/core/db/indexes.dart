/// SQL-вирази створення індексів. Будуть виконані у міграції S3.1
class DbIndexes {
  // Repos
  static const reposTokenScope =
      'CREATE INDEX IF NOT EXISTS idx_repos_token_scope ON repos (token_scope)';
  static const reposFullName =
      'CREATE INDEX IF NOT EXISTS idx_repos_full_name ON repos (full_name)';
  static const reposUpdatedAt =
      'CREATE INDEX IF NOT EXISTS idx_repos_updated_at ON repos (updated_at)';

  // Commits
  static const commitsRepo =
      'CREATE INDEX IF NOT EXISTS idx_commits_repo_full_name ON commits (repo_full_name)';
  static const commitsRepoDate =
      'CREATE INDEX IF NOT EXISTS idx_commits_repo_date ON commits (repo_full_name, date)';
  static const commitsTokenScope =
      'CREATE INDEX IF NOT EXISTS idx_commits_token_scope ON commits (token_scope)';

  // Activity
  static const activityRepo =
      'CREATE INDEX IF NOT EXISTS idx_activity_repo_full_name ON activity (repo_full_name)';
  static const activityDate =
      'CREATE INDEX IF NOT EXISTS idx_activity_date ON activity (date)';
  static const activityTokenScope =
      'CREATE INDEX IF NOT EXISTS idx_activity_token_scope ON activity (token_scope)';

  // Notes
  static const notesUpdatedAt =
      'CREATE INDEX IF NOT EXISTS idx_notes_updated_at ON notes (updated_at)';

  // Note mutations queue
  static const noteMutationsEnqueuedAt =
      'CREATE INDEX IF NOT EXISTS idx_note_mutations_enqueued_at ON note_mutations (enqueued_at)';
  static const noteMutationsNoteId =
      'CREATE INDEX IF NOT EXISTS idx_note_mutations_note_id ON note_mutations (note_id)';
}
