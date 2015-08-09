// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sass/assets/javascripts/bootstrap
//= require angular/angular
//= require angular-ui-bootstrap-bower
//= require codemirror
//= require codemirror/mode/clike/clike
//= require codemirror/mode/d/d
//= require angular-ui-codemirror
//
// Templates in app/assets/javascripts/templates
//= require_tree ./templates
//= require_tree .


// for turbolinks
$(document).on('ready page:load', function() {
    // app 'procgarden' is defined at procgarden.ts.erb
    angular.bootstrap(document.body, ['procgarden']);
});