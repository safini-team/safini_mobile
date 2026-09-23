package com.safini.app

import org.junit.Assert.assertEquals
import org.junit.Test

class DeviceLanguageTest {
    @Test fun russianPhoneOpensInRussian() =
        assertEquals("ru", resolvePhoneLanguage(listOf("ru")))

    @Test fun englishPhoneOpensInEnglish() =
        assertEquals("en", resolvePhoneLanguage(listOf("en")))

    @Test fun uzbekIsNeverAutoSelected() =
        assertEquals("ru", resolvePhoneLanguage(listOf("uz")))

    @Test fun uzbekThenRussianLandsOnRussian() =
        assertEquals("ru", resolvePhoneLanguage(listOf("uz", "ru", "en")))

    @Test fun uzbekThenEnglishLandsOnEnglish() =
        assertEquals("en", resolvePhoneLanguage(listOf("uz", "en")))

    @Test fun unknownLocalesFallBackToRussian() =
        assertEquals("ru", resolvePhoneLanguage(listOf("kk", "de")))
}
