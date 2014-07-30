function DBStore() {
	self.env = undefined;
	self.lastShift = undefined;
	self.doublePressTime = 200;
	self.lastChecked = undefined;
	
	this.init = function() {
		var dbstore = this;
		$(document).ready(function(){
			if (dbstore.env == "development") {
				dbstore.bindOpenDBStore();
				dbstore.bindButtons();
				dbstore.editList();
				dbstore.shiftClick();
				dbstore.alertStale();
			}
		});
	}
	this.bindOpenDBStore = function() {
		$(window).keydown(function(event) {
		  if (event.keyCode == 16) { // Shift
				var now = Date.now();
		  	if (self.lastShift != undefined) {
					if ((now - self.lastShift) < self.doublePressTime) {
						$("#db_store").addClass("db_store_active")
					}
				}
				self.lastShift = now;
			}
		});
	}
	this.restoreAjax = function() {
		this.bindButtons();
		this.editList();
		this.shiftClick();
		this.alertStale();
	}
	this.editList = function() {
		var dbstore = this;
		$("#db_store_edit_list").click(function() {
			dbstore.showList();
		})
	}
	this.showList = function() {
		$("#db_store_edit_list").hide();
		$("#db_store_list").show();
	}
	this.bindButtons = function() {
		var dbstore = this;
		$("#db_store form").submit(function(event) {
			dbstore.message("sending...")
			var form = $(event.target);
			$.post(form.attr('action'), form.serialize())
			return false;
		})
	}
	this.shiftClick = function() {
		var dbstore = this;
		var checkBoxes = $("#db_store input[type='checkbox']")
		checkBoxes.click(function(event) {
			var target = $(event.target);
			var newState = target.is(":checked");
			if (!dbstore.lastChecked) {
				dbstore.lastChecked = target;
				return;
			}
			if (event.shiftKey) {
				var start = checkBoxes.index(target);
				var end = checkBoxes.index(dbstore.lastChecked);
				checkBoxes.slice(Math.min(start,end), Math.max(start,end) + 1).attr("checked", newState);
			}
			dbstore.lastChecked = target;
		})
	}
	this.alertStale = function() {
		$("#db_store select").change(function(event) {
			var isStale = $(event.target).find(":selected").hasClass("db_store_stale");
			var warning = $(event.target).siblings(".db_store_stale_warning");
			if (isStale) { warning.addClass("db_store_active"); }
			else { warning.removeClass("db_store_active"); }
		});
	}
	this.message = function(msg) {
		$("#db_store #db_store_message").html(msg);
	}
}