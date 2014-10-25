(function() {
  define(['jquery'], function($) {
    var Header;
    Header = (function() {
      function Header(calendar) {
        this.calendar = calendar;
        this.initHtml();
        this.bindHandlers();
      }

      Header.prototype.initHtml = function() {
        this.$prevBtn = $('.prev');
        this.$nextBtn = $('.next');
        this.$todayBtn = $('.today-btn');
        return this.$monthElem = $('.month');
      };

      Header.prototype.bindHandlers = function() {
        this.$prevBtn.on('click', (function(_this) {
          return function() {
            _this.calendar.prevMonth();
            _this.calendar.hidePopup();
            _this.calendar.fullContainer();
          };
        })(this));
        this.$nextBtn.on('click', (function(_this) {
          return function() {
            _this.calendar.nextMonth();
            _this.calendar.hidePopup();
            _this.calendar.fullContainer();
          };
        })(this));
        this.$todayBtn.on('click', (function(_this) {
          return function() {
            _this.calendar.curDate.setMonth(_this.calendar.today.getMonth());
            _this.calendar.curDate.setYear(_this.calendar.today.getFullYear());
            _this.calendar.hidePopup();
            _this.calendar.fullContainer();
          };
        })(this));
      };

      return Header;

    })();
    return Header;
  });

}).call(this);