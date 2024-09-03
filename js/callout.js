function getCalloutText(dateString, phrase) {
  if (!dateString) return phrase

  const date = new Date(dateString)
  const now = new Date()
  const tomorrow = new Date(now)
  tomorrow.setDate(now.getDate() + 1)

  if (isSameDay(date, now)) {
    return `${phrase} today`
  }

  if (isSameDay(date, tomorrow)) {
    return `${phrase} tomorrow`
  }

  if (date > now) {
    return `${phrase} ${getRelativeTimePhrase(date)}`
  }

  return phrase
}

function isSameDay(date1, date2) {
  return (
    date1.getFullYear() === date2.getFullYear() &&
    date1.getMonth() === date2.getMonth() &&
    date1.getDate() === date2.getDate()
  )
}

function getRelativeTimePhrase(date) {
  const rtf = new Intl.RelativeTimeFormat('en', { numeric: 'auto' })
  const diffDays = Math.ceil((date - new Date()) / (1000 * 60 * 60 * 24))

  if (Math.abs(diffDays) < 7) {
    return rtf.format(diffDays, 'day')
  }

  if (Math.abs(diffDays) < 30) {
    return rtf.format(Math.floor(diffDays / 7), 'week')
  }

  if (Math.abs(diffDays) < 365) {
    return rtf.format(Math.floor(diffDays / 30), 'month')
  }

  return rtf.format(Math.floor(diffDays / 365), 'year')
}

function updateCallouts() {
  document.querySelectorAll('[data-phrase]').forEach(element => {
    const { date, phrase } = element.dataset
    const calloutText = getCalloutText(date, phrase)

    if (calloutText !== phrase) {
      element.textContent = calloutText
    }

    element.remove()
  })
}

document.addEventListener('DOMContentLoaded', updateCallouts)
