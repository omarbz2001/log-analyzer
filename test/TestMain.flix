@Test
def testParseLine_validError(): Unit \ Assert =
    match Parser.parseLine("2026-05-13 ERROR Database failed") {
        case Some(_) => Assert.assertTrue(true)
        case None    => Assert.assertTrue(false)
    }
@Test
def testParseLine_validInfo(): Unit \ Assert =
    match Parser.parseLine("2026-05-13 INFO User logged in") {
        case Some(_) => Assert.assertTrue(true)
        case None    => Assert.assertTrue(false)
    }

@Test
def testParseLine_malformed(): Unit \ Assert =
    match Parser.parseLine("this is not valid") {
        case Some(_) => Assert.assertTrue(false)
        case None    => Assert.assertTrue(true)
    }

@Test
def testParseLine_unknownLevel(): Unit \ Assert =
    match Parser.parseLine("2026-05-13 CRITICAL Something") {
        case Some(_) => Assert.assertTrue(false)
        case None    => Assert.assertTrue(true)
    }
@Test
def testClassifier_keepError(): Unit \ Assert =
    Assert.assertTrue(Classifier.keep(LogEntry.LogEntry("2026-05-13", LogLevel.Error, "msg")))

@Test
def testClassifier_keepInfo(): Unit \ Assert =
    Assert.assertTrue(Classifier.keep(LogEntry.LogEntry("2026-05-13", LogLevel.Info, "msg")))

@Test
def testClassifier_dropDebug(): Unit \ Assert =
    Assert.assertFalse(Classifier.keep(LogEntry.LogEntry("2026-05-13", LogLevel.Debug, "msg")))

@Test
def testClassifier_isAlert_error(): Unit \ Assert =
    Assert.assertTrue(Classifier.isAlert(LogEntry.LogEntry("2026-05-13", LogLevel.Error, "msg")))

@Test
def testClassifier_isAlert_warn(): Unit \ Assert =
    Assert.assertFalse(Classifier.isAlert(LogEntry.LogEntry("2026-05-13", LogLevel.Warn, "msg")))

@Test
def testAggregator_emptyIsZero(): Unit \ Assert =
    let LogSummary.LogSummary(e, w, i, d) = Aggregator.empty();
    Assert.assertTrue(e == 0 and w == 0 and i == 0 and d == 0)

@Test
def testAggregator_addError(): Unit \ Assert =
    let summary = Aggregator.add(Aggregator.empty(), LogEntry.LogEntry("ts", LogLevel.Error, "msg"));
    let LogSummary.LogSummary(e, _, _, _) = summary;
    Assert.assertTrue(e == 1)

@Test
def testAggregator_addWarn(): Unit \ Assert =
    let summary = Aggregator.add(Aggregator.empty(), LogEntry.LogEntry("ts", LogLevel.Warn, "msg"));
    let LogSummary.LogSummary(_, w, _, _) = summary;
    Assert.assertTrue(w == 1)

@Test
def testAggregator_addInfo(): Unit \ Assert =
    let summary = Aggregator.add(Aggregator.empty(), LogEntry.LogEntry("ts", LogLevel.Info, "msg"));
    let LogSummary.LogSummary(_, _, i, _) = summary;
    Assert.assertTrue(i == 1)