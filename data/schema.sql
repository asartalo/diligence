PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "settings" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "start_of_day" varchar, "max_idle_minutes" integer, "location" json, "news_sources" json, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "task_hierarchies" ("ancestor_id" integer NOT NULL, "descendant_id" integer NOT NULL, "generations" integer NOT NULL);
CREATE TABLE IF NOT EXISTS "tasks" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "parent_id" integer, "client_id" varchar, "done" boolean DEFAULT 0, "old_id" varchar, "sort_order" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "done_at" datetime, "expanded" boolean DEFAULT 0, "old_parent_id" varchar);
CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "next_tasks" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "task_id" integer NOT NULL, "sort_order" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_11ec03fb43"
FOREIGN KEY ("task_id")
  REFERENCES "tasks" ("id")
);
CREATE TABLE IF NOT EXISTS "common_states" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "last_productive_action_at" datetime, "last_load_at" datetime, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "previous_last_load_at" datetime, "page" varchar);
DELETE FROM sqlite_sequence;
INSERT INTO sqlite_sequence VALUES('settings',1);
INSERT INTO sqlite_sequence VALUES('tasks',3542);
INSERT INTO sqlite_sequence VALUES('next_tasks',365);
INSERT INTO sqlite_sequence VALUES('common_states',1);
CREATE UNIQUE INDEX "task_anc_desc_idx" ON "task_hierarchies" ("ancestor_id", "descendant_id", "generations");
CREATE INDEX "task_desc_idx" ON "task_hierarchies" ("descendant_id");
CREATE INDEX "index_tasks_on_old_id" ON "tasks" ("old_id");
CREATE INDEX "index_tasks_on_parent_id" ON "tasks" ("parent_id");
CREATE INDEX "index_next_tasks_on_task_id" ON "next_tasks" ("task_id");
COMMIT;
