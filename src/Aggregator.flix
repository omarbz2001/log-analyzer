mod Aggregator {

    pub def empty(): LogSummary =
        LogSummary.LogSummary(0, 0, 0, 0)

    pub def add(summary: LogSummary, entry: LogEntry): LogSummary =
        let LogSummary.LogSummary(errors, warns, infos, debugs) = summary;
        let LogEntry.LogEntry(_, level, _) = entry;
        match level {
            case LogLevel.Error => LogSummary.LogSummary(errors + 1, warns,     infos,     debugs)
            case LogLevel.Warn  => LogSummary.LogSummary(errors,     warns + 1, infos,     debugs)
            case LogLevel.Info  => LogSummary.LogSummary(errors,     warns,     infos + 1, debugs)
            case LogLevel.Debug => LogSummary.LogSummary(errors,     warns,     infos,     debugs + 1)
        }

    pub def report(summary: LogSummary): String =
        let LogSummary.LogSummary(errors, warns, infos, debugs) = summary;
        "=== Log Summary ===" + "\n" +
        "ERROR : " + Int32.toString(errors) + "\n" +
        "WARN  : " + Int32.toString(warns)  + "\n" +
        "INFO  : " + Int32.toString(infos)  + "\n" +
        "DEBUG : " + Int32.toString(debugs)

}