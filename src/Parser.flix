mod Parser {

    pub def parseLine(line: String): Option[LogEntry] =
        let parts = String.splitOn({substr = " "}, line);
        match parts {
            case ts :: lvl :: rest =>
                let msg = List.join(" ", rest);
                match parseLevel(lvl) {
                    case Some(level) => Some(LogEntry.LogEntry(ts, level, msg))
                    case None        => None
                }
            case _ => None
        }

    def parseLevel(s: String): Option[LogLevel] = match s {
        case "ERROR" => Some(LogLevel.Error)
        case "WARN"  => Some(LogLevel.Warn)
        case "INFO"  => Some(LogLevel.Info)
        case "DEBUG" => Some(LogLevel.Debug)
        case _       => None
    }

}