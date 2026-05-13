use Assert.{assertEq, assertTrue, assertFalse, assertSome, assertNone}

// --- Parser tests ---

@Test
def testParseLine_validError(): Unit \ Assert =
    let result = Parser.parseLine("2026-05-13 ERROR Database failed");
    assertSome(result)

@Test
def testParseLine_validInfo(): Unit \ Assert =
    let result = Parser.parseLine("2026-05-13 INFO User logged in");
    assertSome(result)

@Test
def testParseLine_malformed(): Unit \ Assert =
    let result = Parser.parseLine("this is not a valid log line at all");
    assertNone(result)

@Test
def testParseLine_unknownLevel(): Unit \ Assert =
    let result = Parser.parseLine("2026-05-13 CRITICAL Something happened");
    assertNone(result)

// --- Classifier tests ---

@Test
def testClassifier_keepError(): Unit \ Assert =
    let entry = LogEntry.LogEntry("2026-05-13", LogLevel.Error, "msg");
    assertTrue(Classifier.keep(entry))

@Test
def testClassifier_keepInfo(): Unit \ Assert =
    let entry = LogEntry.LogEntry("2026-05-13", LogLevel.Info, "msg");
    assertTrue(Classifier.keep(entry))

@Test
def testClassifier_dropDebug(): Unit \ Assert =
    let entry = LogEntry.LogEntry("2026-05-13", LogLevel.Debug, "msg");
    assertFalse(Classifier.keep(entry))

@Test
def testClassifier_isAlert_error(): Unit \ Assert =
    let entry = LogEntry.LogEntry("2026-05-13", LogLevel.Error, "msg");
    assertTrue(Classifier.isAlert(entry))

@Test
def testClassifier_isAlert_warn(): Unit \ Assert =
    let entry = LogEntry.LogEntry("2026-05-13", LogLevel.Warn, "msg");
    assertFalse(Classifier.isAlert(entry))

// --- Aggregator tests ---

@Test
def testAggregator_emptyIsZero(): Unit \ Assert =
    let LogSummary.LogSummary(e, w, i, d) = Aggregator.empty();
    assertEq(expected = 0, e);
    assertEq(expected = 0, w);
    assertEq(expected = 0, i);
    assertEq(expected = 0, d)

@Test
def testAggregator_addError(): Unit \ Assert =
    let summary = Aggregator.add(Aggregator.empty(), LogEntry.LogEntry("ts", LogLevel.Error, "msg"));
    let LogSummary.LogSummary(e, _, _, _) = summary;
    assertEq(expected = 1, e)

@Test
def testAggregator_addWarn(): Unit \ Assert =
    let summary = Aggregator.add(Aggregator.empty(), LogEntry.LogEntry("ts", LogLevel.Warn, "msg"));
    let LogSummary.LogSummary(_, w, _, _) = summary;
    assertEq(expected = 1, w)

@Test
def testAggregator_addInfo(): Unit \ Assert =
    let summary = Aggregator.add(Aggregator.empty(), LogEntry.LogEntry("ts", LogLevel.Info, "msg"));
    let LogSummary.LogSummary(_, _, i, _) = summary;
    assertEq(expected = 1, i)