var playback = require('../lib/playback.js');

describe('playback', function() {
  it('should record a request and playback that request', function() {
    var play = playback.playback();

    play.record('request key', 'response data');

    var output = play.playback();

    expect(output).toContain('request key');
    expect(output).toContain('response data');
  });
});
