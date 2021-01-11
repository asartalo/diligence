CREATE TABLE IF NOT EXISTS "day_log" (
	"id"	integer NOT NULL PRIMARY KEY AUTOINCREMENT,
	"day"   date NOT NULL,
    "notes" text,
    "completed" integer NOT NULL DEFAULT 0,
    "overdue" integer NOT NULL DEFAULT 0,
    "newly_created" integer NOT NULL DEFAULT 0,
    "breakdowns" json
);

CREATE UNIQUE INDEX IF NOT EXISTS "index_day_log_day" ON "day_log" (
    "day"
);