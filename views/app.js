angular.module('app', ['ngRoute'])

.config(function($routeProvider) {
    $routeProvider
        .when('/', {
            controller: 'SourcesCtrl',
            templateUrl: 'sources.html'
        })
        .when('/topics', {
            controller: 'TopicsCtrl',
            templateUrl: 'topics.html'
        })
        .otherwise({
            redirectTo: '/'
        });
})

.factory('SelectedSources', function() {
    return {
        sources: []
    };
})

.controller('SourcesCtrl', function($scope, $location, SelectedSources) {

    $scope.selectedSources = SelectedSources.sources;

    $scope.sources = [
        'The New York Times',
        'The Wall Street Journal',
        'TechCrunch'
    ];

    $scope.sources.forEach(function(source) {
        $scope.selectedSources.push({
            name: source,
            selected: false
        });
    });

    $scope.saveSources = function() {
        $location.path('/topics');
    };
})

.controller('TopicsCtrl', function($scope, SelectedSources) {

    $scope.selectedSources = SelectedSources.sources;

    $scope.topics = [
        'Africa',
        'Americas',
        'Asia Pacific',
        'Middle East',
        'Europe',
        'Education',
        'Technology',
        'Weather',
        'Sports',
        'Arts'
    ];

    $scope.selectedSources.forEach(function(source) {
        if (source.selected) {
            source.topics = [];
            $scope.topics.forEach(function(topic) {
                source.topics.push({
                    name: topic,
                    selected: false
                });
            });
        };
    });
    $scope.saveTopics = function() {
        var finalSources = [];
        $scope.selectedSources.forEach(function(source) {
            if (source.selected) {
                var finalTopics = [];
                source.topics.forEach(function(topic) {
                    if (topic.selected) {
                        finalTopics.push(topic.name);
                    };
                });
                finalSources.push({
                    name: source.name,
                    topics: finalTopics
                });
                console.log(finalSources)
                $.ajax({
                	type: "POST",
                	url: "http://localhost:5000" + '/topics',
                    dataType: 'jsonp',
                    data: {
                        topics: finalTopics,
                    },
                });
            };
        });
    };

});
