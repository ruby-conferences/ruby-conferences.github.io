(function() {
  $(function() {
    var $event_list;
    $event_list = {
      calloutText: function(dateData, phraseData) {
        var date, now;
        date = dateData ? moment(dateData) : false;
        if (!date) {
          return phraseData;
        }
        now = moment();
        switch (false) {
          case !date.isSame(now, 'day'):
            return phraseData + " today";
          case !date.isSame(now.add(1, 'day'), 'day'):
            return phraseData + " tomorrow";
          case !date.isAfter(now):
            return phraseData + " " + (date.endOf('day').fromNow());
        }
      },
      addCallout: function() {
        var dateData, phrase, phraseData;
        dateData = $(this).data().date;
        phraseData = $(this).data().phrase;
        phrase = $event_list.calloutText(dateData, phraseData);
        if (phrase) {
          return $(this).text(phrase);
        } else {
          return $(this).remove();
        }
      },
      init: function() {
        return $("[data-phrase]").each(this.addCallout);
      }
    };
    return $event_list.init();
  });

}).call(this);
