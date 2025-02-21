local locale = {}

if not SMODS then
    locale = {
        ['de'] = require('systemclock.locale.de').misc.dictionary,
        ['en-us'] = require('systemclock.locale.en-us').misc.dictionary,
        ['es_419'] = require('systemclock.locale.es_419').misc.dictionary,
        ['es_ES'] = require('systemclock.locale.es_es').misc.dictionary,
        ['fr'] = require('systemclock.locale.fr').misc.dictionary,
        ['id'] = require('systemclock.locale.id').misc.dictionary,
        ['it'] = require('systemclock.locale.it').misc.dictionary,
        ['ja'] = require('systemclock.locale.ja').misc.dictionary,
        ['ko'] = require('systemclock.locale.ko').misc.dictionary,
        ['nl'] = require('systemclock.locale.nl').misc.dictionary,
        ['pl'] = require('systemclock.locale.pl').misc.dictionary,
        ['pt_BR'] = require('systemclock.locale.pt_br').misc.dictionary,
        ['ru'] = require('systemclock.locale.ru').misc.dictionary,
        ['vi'] = require('systemclock.locale.vi').misc.dictionary,
        ['zh_CN'] = require('systemclock.locale.zh_cn').misc.dictionary,
        ['zh_TW'] = require('systemclock.locale.zh_tw').misc.dictionary
    }
end

function locale.translate(key)
    if SMODS then return localize(key) end
    return locale[G.SETTINGS.language][key] or locale['en-us'][key] or 'ERROR'
end

return locale
