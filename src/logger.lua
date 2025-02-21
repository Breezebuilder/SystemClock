local logger = {}

function logger.log_trace(message)
    logger.log("TRACE", message)
end

function logger.log_debug(message)
    logger.log("DEBUG", message)
end

function logger.log_info(message)
    logger.log("INFO ", message)
end

function logger.log_warn(message)
    logger.log("WARN ", message)
end

function logger.log_error(message)
    logger.log("ERROR", message)
end

function logger.log_fatal(message)
    logger.log("FATAL", message)
end

function logger.log(level, message)
    if not message then return end
    level = level or "LOG  "
    local date = os.date('%Y-%m-%d %H:%M:%S')
    print(date .. " :: " .. level .. " :: SystemClock :: " .. message)
end

return logger
