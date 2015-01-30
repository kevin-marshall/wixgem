require 'rspec'
require './lib/command.rb'

describe 'Command' do
  it 'should be able to execute: dir' do
    cmd = Wixgem::Command.new('dir', { quiet: true })
	cmd.execute
	expect(cmd[:output].empty?).to eq(false)
	expect(cmd[:output].include?('Directory')).to eq(true)
  end

  it 'should fail executing: isnotacommand' do
    cmd = Wixgem::Command.new('isnotacommand', { quiet: true })
	expect { cmd.execute }.to raise_error
	expect(cmd[:error].include?('No such file or directory')).to eq(true)
	expect(cmd[:exit_status]).to_not eq(0)
  end
end
