CREATE TABLE IF NOT EXISTS "day_logs" (
	"day"   date NOT NULL PRIMARY KEY,
    "notes" text,
    "completed" integer NOT NULL DEFAULT 0,
    "overdue" integer NOT NULL DEFAULT 0,
    "newly_created" integer NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS "day_log_breakdowns" (
    "id" integer NOT NULL PRIMARY KEY,
	"task_id" integer NOT NULL,
	"path" text,
    "completed" date,
    "overdue" date,
    "newly_created" date,
    "updated_at" date DEFAULT (datetime('now','utc')),
);

CREATE INDEX IF NOT EXISTS "index_day_log_breakdowns_completed" ON "day_log_breakdowns" (
    "completed"
);

CREATE INDEX IF NOT EXISTS "index_day_log_breakdowns_overdue" ON "day_log_breakdowns" (
    "overdue"
);

CREATE INDEX IF NOT EXISTS "index_day_log_breakdowns_overdue" ON "day_log_breakdowns" (
    "newly_created"
);

CREATE INDEX IF NOT EXISTS "index_day_log_breakdowns_path" ON "day_log_breakdowns" (
    "path"
);

CREATE TABLE IF NOT EXISTS "task_name_map" (
	"id" integer NOT NULL PRIMARY KEY,
    "name" text,
);
