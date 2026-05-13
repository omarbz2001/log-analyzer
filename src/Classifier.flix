mod Classifier {

    pub def keep(entry: LogEntry): Bool =
        let LogEntry.LogEntry(_, level, _) = entry;
        match level {
            case LogLevel.Debug => false
            case _              => true
        }

    pub def isAlert(entry: LogEntry): Bool =
        let LogEntry.LogEntry(_, level, _) = entry;
        match level {
            case LogLevel.Error => true
            case _              => false
        }

}