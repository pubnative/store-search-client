require 'spec_helper'

RSpec.describe StoreSearch::PlayStoreParser do
  let(:bot) do
    OpenStruct.new({
      title: 'some title',
      description: '<html> <h1>&bdquo;&#9733; some<br>more <br/>description<p>and</p> other<br />stuff &#9733;&ldquo;</h1> hidden<div style="display: none;">text </html>',
      developer: ' Spotify Ltd. ',
      current_version: 'Varies on device',
      size: 'Varies on device',
      updated: 'May 21, 2014',
      requires_android: '1.1',
      content_rating: 'Everyone',
      rating: "4.4",
      category: "Music & Audio",
      screenshot_urls: %w[http://img.com/1 http://img.com/2],
      votes: "1500",
      installs: "10,000 - 20,000",
      website_url: 'https://www.spotify.com/',
      cover_image_url: 'http://banner.icon'
    })
  end

  let(:results_hash) do
    {
      title: 'some title',
      description: "„★ some\nmore \ndescription\n and  other\nstuff ★“  hidden",
      publisher: 'Spotify Ltd.',
      developer: 'Spotify Ltd.',
      version: 'Varies on device',
      memory: 'Varies on device',
      release_date: Time.parse("2014-05-21 00:00:00"),
      min_os_version: '1.1',
      age_rating: 'Everyone',
      rating: "4.4",
      categories: ["Music & Audio"],
      icon_url: 'http://banner.icon',
      screenshot_urls: %w[http://img.com/1 http://img.com/2],
      platforms: %w[Android],
      supported_devices: [],
      total_ratings: "1500",
      installs: "10,000 - 20,000",
      developer_website: 'https://www.spotify.com/'
    }
  end

  subject { StoreSearch::PlayStoreParser.new bot }

  its(:title) { should be == 'some title' }
  its(:description) { should be == "„★ some\nmore \ndescription\n and  other\nstuff ★“  hidden" }
  its(:publisher) { should be == "Spotify Ltd." }
  its(:developer) { should be == "Spotify Ltd." }
  its(:version) { should be == "Varies on device" }
  its(:memory) { should be == "Varies on device" }
  its(:release_date) { should be == Time.parse("2014-05-21 00:00:00") }
  its(:min_os_version) { should be == "1.1" }
  its(:age_rating) { should be == "Everyone" }
  its(:rating) { should be == "4.4" }
  its(:categories) { should match_array(["Music & Audio"]) }
  its(:screenshot_urls) { should be == %w[http://img.com/1 http://img.com/2] }
  its(:platforms) { should be == %w[Android] }
  its(:supported_devices) { should be == [] }
  its(:total_ratings) { should be == "1500" }
  its(:installs) { should be == "10,000 - 20,000" }
  its(:developer_website) { should be == 'https://www.spotify.com/' }
  its(:icon_url) { should be == 'http://banner.icon' }

  its(:to_hash) { should be == results_hash }

  describe '.parse' do
    subject { StoreSearch::PlayStoreParser.parse(bot) }
    it { should be == results_hash }
  end

  describe '#min_os_version' do
    def parse_min_os_version(version)
      StoreSearch::PlayStoreParser.new(OpenStruct.new(requires_android: version)).min_os_version
    end

    context 'when requires_android is nil' do
      it 'returns nil' do
        expect(parse_min_os_version(nil)).to be(nil)
      end
    end

    context 'when requires_android has a valid format' do
      it 'converts it to version string' do
        expect(parse_min_os_version('1')).to eq('1')
        expect(parse_min_os_version('1.')).to eq('1')
        expect(parse_min_os_version('1.2')).to eq('1.2')
        expect(parse_min_os_version('1.2.3')).to eq('1.2.3')
        expect(parse_min_os_version('12.34.56')).to eq('12.34.56')
        expect(parse_min_os_version('1.2a')).to eq('1.2')
        expect(parse_min_os_version('1.2 and up')).to eq('1.2')
      end
    end

    context 'when requires_android has invalid format' do
      it 'returns nil' do
        expect(parse_min_os_version('.1')).to be(nil)
        expect(parse_min_os_version('a1.2')).to be(nil)
        expect(parse_min_os_version('Varies with device')).to be(nil)
      end
    end
  end

  describe '#description' do
    def parse_description(description)
      StoreSearch::PlayStoreParser.new(OpenStruct.new(description: description)).description
    end

    context 'when description is usual' do
      it 'returns parsed and decoded description' do
        description = '<html> <h1>&bdquo;&#9733; some<br>more <br/>description<p>and</p> other<br />stuff &#9733;&ldqu'\
        'o;</h1> hidden<div style="display: none;">text </html>'
        expect(parse_description(description)).to eq("„★ some\nmore \ndescription\n and  other\nstuff ★“  hidden")
      end
    end

    context 'when description exceeds default tree depth limit' do
      it 'returns parsed and decoded description' do
        description = '<span jsslot><div jsname=\"sngebd\">Backgammon is one of the world&rsquo;s most popular board g'\
        'ames, brought to you by the makers of Nonogram.com and Sudoku.com puzzles. Install Backgammon for free now, t'\
        'rain your brain and have fun!\n\nBackgammon board game (also known as Nardi or Tawla ) is one of the oldest l'\
        'ogic games in existence, alongside Chess and Go. People from all over the world have been playing backgammon '\
        'classic for more than 5000 years to socialize with family and friends and keep their brains active.\n\nHow to'\
        ' play the Backgammon classic game\n\n- Classic Backgammon is a logic puzzle for two, played on a board of 24 '\
        'triangles. These triangles are called points.\n- Each player sits on the opposite sides of the board with 15 '\
        'checkers, black or white.\n- To start the game, players take turns and roll the dice. That&rsquo;s why free B'\
        'ackgammon is often called a dice game.\n- Players move pieces based on the numbers rolled. For example, if yo'\
        'u roll 2 and 5, you can move one piece 2 points and another one 5 points. Alternatively, you can move one pie'\
        'ce 7 points.\n- Once all of a player&rsquo;s pieces are on the opponent&rsquo;s &ldquo;home&rdquo;, that play'\
        'er may begin removing pieces off of the board.\n- A player wins once all of their pieces are removed from the'\
        ' board\n\nA few more things to know\n\n- Rolling two of the same number allows you to move 4 times. For examp'\
        'le, for a roll of 4 and 4, you can move a total of 16 points, although each piece must move 4 points at a tim'\
        'e.\n- You cannot move a piece to a point that is occupied by 2 or more of your opponent&rsquo;s pieces\n- If '\
        'you move a piece to a point with only 1 of your opponent&rsquo;s pieces on it, the rival&rsquo;s piece is rem'\
        'oved from the board and placed on the middle partition.\n\nBackgammon Free Features\n\n- Enjoy a fair dice ro'\
        'll, which only the best backgammon games can boast.\n- Undo a move if you made it accidentally or came up wit'\
        'h a better one right after\n- Your possible moves are highlighted to help you make an easier decision\n- A si'\
        'mple and intuitive design to better focus on the game\n- Start with easy opponents and face more difficult on'\
        'es as you practice on your way to becoming the Backgammon king.\n\nInteresting facts about Backgammon\n\n- An'\
        'cient Romans, Greeks, and Egyptians all loved playing Backgammon (known as tawla or narde). \n- Backgammon is'\
        ' a classic game of luck and strategy. While any dice game is pretty much pure luck, there&rsquo;s also an inf'\
        'inite number of strategies that even include predicting your opponent&rsquo;s moves.\n- One thing logic games'\
        ' have in common &ndash; they keep your brain sharp. It may not be difficult to learn the basics of Backgammon'\
        ', but you&rsquo;ll need an entire lifetime to become a true lord of the board.\n\nBackgammon Classic is one o'\
        'f the most popular free board games ever. Download it now and challenge yourself!</div></span><div jsname=\"W'\
        'gKync\" class=\"uwAgLc f3Fr9d\"></div>'

        expect(parse_description(description)).to start_with('Backgammon is one of the world’s most popular')
        expect(parse_description(description)).to end_with('Download it now and challenge yourself!')
      end
    end
  end
end
