# frozen-string-literal: true

# Standalone: the hook is a bash script, so this spec runs it with bash and needs no spec_helper.
describe 'etc/rbenv.d/exec/~gem-src.bash' do
  let(:hook) { File.expand_path('../etc/rbenv.d/exec/~gem-src.bash', __dir__) }
  let(:lib) { File.expand_path('../lib', __dir__) }

  # rbenv sources the hook once per `rbenv exec`, and a shim's ruby shebang nests a second exec
  def rubylib_after_sourcing(times, initial: nil)
    script = (["source '#{hook}'"] * times).push('printf %s "$RUBYLIB"').join(' && ')
    IO.popen({ 'RUBYLIB' => initial }, ['bash', '-c', script], &:read)
  end

  it 'prepends lib to RUBYLIB' do
    expect(rubylib_after_sourcing(1, initial: '/other').split(':')).to eq [lib, '/other']
  end

  it 'adds lib only once when sourced repeatedly' do
    expect(rubylib_after_sourcing(3).split(':').count(lib)).to eq 1
  end

  it 'does not add lib again when RUBYLIB already has it' do
    expect(rubylib_after_sourcing(1, initial: "#{lib}:/other").split(':')).to eq [lib, '/other']
  end
end
