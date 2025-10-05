erDiagram
  %% 関係（どちらも To-One optional ↔ To-Many）
  MATERIAL       |o--o{  DAILY_RECORD : uses      %% Material uses (is used by) DailyRecord
  MONTHLY_RECORD |o--o{  DAILY_RECORD : aggregates

  DAILY_RECORD {
    uuid    id PK
    date    learned_on
    string  review
    boolean alarmOn
    boolean isChecked
    boolean isRepeating
    integer scheduledHour
    integer scheduledMinute
    string  startPage
    string  endPage
    string  startUnit
    string  endUnit
    string  eventIdentifier
  }

  MATERIAL {
    uuid   id PK
    string name
    string label
    bytes  imageData        
  }

  MONTHLY_RECORD {
    uuid id   PK
    int  year
    int  month
    int  checkCount
  }

