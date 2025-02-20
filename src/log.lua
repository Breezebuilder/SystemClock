local log = {}

function log.trace_message(message)
	log.message("TRACE", message)
end

function log.debug_message(message)
    log.message("DEBUG", message)
end

function log.info_message(message)
    log.message("INFO ", message)
end

function log.warn_message(message)
	log.message("WARN ", message)
end

function log.error_message(message)
    log.message("ERROR", message)
end

function log.fatal_message(message)
    log.message("FATAL", message)
end

function log.message(level, message)
    if not message then return end
    level = level or "     "
    local logger = "SystemClock"
    local date = os.date('%Y-%m-%d %H:%M:%S')
    print(date .. " :: " .. level .. " :: " .. logger .. " :: " .. message)
end

return log