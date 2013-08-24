module.exports = (data, date) -> """
@Application Name : #{data.displayname or data.name}
@Author           : #{data.author.name} <#{data.author.email}>
@Version          : #{data.version}
@Date Compiled    : #{date.toString()}
"""
