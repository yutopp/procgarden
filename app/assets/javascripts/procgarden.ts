/// <reference path="./typings/angularjs/angular.d.ts"/>

module ProcGarden {
    export module EntryDirective {
        class Controller {
            constructor(private $http: ng.IHttpService) {
            }
        }

        export class Directive implements ng.IDirective {
            restrict = 'AE';
            transclude = true;
            replace = true;
            scope = {};
            bindToController = {
            };
            controller = ['$http', Controller];
            controllerAs = 'ctrl';

            template = `
                <div>
                testtest
                </div>
                `;

        }
    }

    var app = angular.module("procgarden", []);

    app
        .directive("procgardenEntry", () => new EntryDirective.Directive())

    console.log('loaded');
}