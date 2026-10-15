package com.safini.app

import org.junit.Assert.assertEquals
import org.junit.Test
import java.io.File
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.ZoneId

/** The window math against the fixture the API's tests use (`test/fixtures/fini_windows.json`). */
class TimeWindowsTest {
    private val fixture = listOf("../test/fixtures/fini_windows.json", "../../test/fixtures/fini_windows.json")
        .map(::File).first { it.exists() }.readText()
    private val tashkent = ZoneId.of("Asia/Tashkent")

    private val windows = Regex(""""(\w+)": \{"start": "([\d:]+)", "end": "([\d:]+)", "days": (\d+)\}""")
        .findAll(fixture).associate { m ->
            val (name, start, end, days) = m.destructured
            name to TimeWindows.Window(name, LocalTime.parse(start), LocalTime.parse(end), days.toInt())
        }

    @Test fun everyFixtureCaseMatchesTheApi() {
        val cases = Regex(""""name": "([^"]+)", "on": \[([^\]]*)\], "at": "([^"]+)", "until": (null|"[\d:]+")""")
            .findAll(fixture).toList()
        assertEquals(13, cases.size)
        for (case in cases) {
            val (name, on, at, until) = case.destructured
            val active = on.split(",").map { windows.getValue(it.trim().trim('"')) }
            val now = LocalDateTime.parse(at).atZone(tashkent)
            val found = TimeWindows.active(active, now)?.second?.toLocalTime()?.toString()
            assertEquals(name, until.trim('"').takeIf { it != "null" }, found)
        }
    }
}
