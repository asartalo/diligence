BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "task_defers" (
	"id"	integer NOT NULL PRIMARY KEY AUTOINCREMENT,
	"task_id"	integer NOT NULL,
	"duration"	float NOT NULL,
	"created_at"	datetime(6) NOT NULL,
	"updated_at"	datetime(6) NOT NULL,
	CONSTRAINT "fk_rails_d065b8a11b" FOREIGN KEY("task_id") REFERENCES "tasks"("id")
);
CREATE TABLE IF NOT EXISTS "tasks" (
	"id"	integer NOT NULL,
	"name"	varchar DEFAULT NULL,
	"parent_id"	integer DEFAULT NULL,
	"client_id"	varchar DEFAULT NULL,
	"done"	boolean DEFAULT 0,
	"old_id"	varchar DEFAULT NULL,
	"sort_order"	integer DEFAULT NULL,
	"created_at"	datetime(6) NOT NULL,
	"updated_at"	datetime(6) NOT NULL,
	"done_at"	datetime DEFAULT NULL,
	"expanded"	boolean DEFAULT 0,
	"old_parent_id"	varchar DEFAULT NULL,
	"primary_focused_at"	datetime,
	PRIMARY KEY("id")
);
CREATE TABLE IF NOT EXISTS "common_states" (
	"id"	integer NOT NULL PRIMARY KEY AUTOINCREMENT,
	"last_productive_action_at"	datetime,
	"last_load_at"	datetime,
	"created_at"	datetime(6) NOT NULL,
	"updated_at"	datetime(6) NOT NULL,
	"previous_last_load_at"	datetime,
	"page"	varchar
);
CREATE TABLE IF NOT EXISTS "next_tasks" (
	"id"	integer NOT NULL PRIMARY KEY AUTOINCREMENT,
	"task_id"	integer NOT NULL,
	"sort_order"	integer,
	"created_at"	datetime(6) NOT NULL,
	"updated_at"	datetime(6) NOT NULL,
	CONSTRAINT "fk_rails_11ec03fb43" FOREIGN KEY("task_id") REFERENCES "tasks"("id")
);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" (
	"key"	varchar NOT NULL,
	"value"	varchar,
	"created_at"	datetime(6) NOT NULL,
	"updated_at"	datetime(6) NOT NULL,
	PRIMARY KEY("key")
);
CREATE TABLE IF NOT EXISTS "schema_migrations" (
	"version"	varchar NOT NULL,
	PRIMARY KEY("version")
);
CREATE TABLE IF NOT EXISTS "task_hierarchies" (
	"ancestor_id"	integer NOT NULL,
	"descendant_id"	integer NOT NULL,
	"generations"	integer NOT NULL
);
CREATE TABLE IF NOT EXISTS "settings" (
	"id"	integer NOT NULL PRIMARY KEY AUTOINCREMENT,
	"start_of_day"	varchar,
	"max_idle_minutes"	integer,
	"location"	json,
	"news_sources"	json,
	"created_at"	datetime(6) NOT NULL,
	"updated_at"	datetime(6) NOT NULL
);
CREATE INDEX IF NOT EXISTS "index_task_defers_on_task_id" ON "task_defers" (
	"task_id"
);
CREATE INDEX IF NOT EXISTS "index_tasks_on_parent_id" ON "tasks" (
	"parent_id"
);
CREATE INDEX IF NOT EXISTS "index_tasks_on_old_id" ON "tasks" (
	"old_id"
);
CREATE INDEX IF NOT EXISTS "index_next_tasks_on_task_id" ON "next_tasks" (
	"task_id"
);
CREATE INDEX IF NOT EXISTS "task_desc_idx" ON "task_hierarchies" (
	"descendant_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "task_anc_desc_idx" ON "task_hierarchies" (
	"ancestor_id",
	"descendant_id",
	"generations"
);
COMMIT;
