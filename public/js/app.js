MonitorCtrl = function($scope) {
  var source, addRequestToTable;
  source = new EventSource('/subscribe');
  $scope.requests = [];

  addRequestToTable = function(event) {
    request = JSON.parse(event.data);
    console.log("Got data - " + event.data);
    $scope.$apply(function () {
      $scope.requests.push(request);
    });
  };

  source.addEventListener('boom', addRequestToTable, false);

}
