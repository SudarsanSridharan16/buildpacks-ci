# encoding: utf-8
require 'spec_helper'
require_relative '../../../tasks/update-buildpack-dependency/dependencies'

describe Dependencies do
  subject {
    described_class.new(
        dep,
        line,
        removal_strategy,
        dependencies,
        master_dependencies
    ).switch
  }
  let(:dependencies) {[
      {'name' => 'bundler', 'version' => '1.2.3'},
      {'name' => 'ruby', 'version' => '1.2.3'},
      {'name' => 'ruby', 'version' => '1.2.4'},
      {'name' => 'ruby', 'version' => '1.3.4'},
      {'name' => 'ruby', 'version' => '2.3.4'},
      {'name' => 'ruby', 'version' => '2.3.6'}
  ].freeze}
  let(:master_dependencies) {[
      {'name' => 'bundler', 'version' => '1.2.1'},
      {'name' => 'ruby', 'version' => '1.2.2'},
      {'name' => 'ruby', 'version' => '1.2.3'},
      {'name' => 'ruby', 'version' => '2.3.1'},
      {'name' => 'ruby', 'version' => '2.3.2'}
  ]}

  context 'no version line specified' do
    let(:line) {nil}
    let(:removal_strategy) {'remove_all'}

    context 'new version is newer than all existing' do
      let(:dep) {{'name' => 'ruby', 'version' => '3.0.0'}}
      it 'replaces all of the named dependencies' do
        expect(subject).to eq([
                                  {'name' => 'bundler', 'version' => '1.2.3'},
                                  {'name' => 'ruby', 'version' => '3.0.0'}
                              ])
      end
    end
    context 'new version is older than any existing' do
      let(:dep) {{'name' => 'ruby', 'version' => '2.0.0'}}
      it 'returns unchanged dependencies' do
        expect(subject).to eq(dependencies)
      end
    end
  end

  context 'version line is major' do
    let(:line) {"major"}
    let(:removal_strategy) {'remove_all'}

    context 'new version is newer than all existing on its line' do
      let(:dep) {{'name' => 'ruby', 'version' => '1.4.0'}}
      it 'replaces all of the named dependencies on its line' do
        expect(subject).to eq([
                                  {'name' => 'bundler', 'version' => '1.2.3'},
                                  {'name' => 'ruby', 'version' => '1.4.0'},
                                  {'name' => 'ruby', 'version' => '2.3.4'},
                                  {'name' => 'ruby', 'version' => '2.3.6'}
                              ])
      end
    end
    context 'new version is part of a new line' do
      let(:dep) {{'name' => 'ruby', 'version' => '3.0.0'}}
      it 'Maintains all old dependencies and adds the new one' do
        expect(subject).to eq(dependencies + [
            {'name' => 'ruby', 'version' => '3.0.0'}
        ])
      end
    end
    context 'new version is older than any existing on its line' do
      let(:dep) {{'name' => 'ruby', 'version' => '2.3.5'}}
      it 'returns unchanged dependencies' do
        expect(subject).to eq(dependencies)
      end
    end
  end

  context 'version line is minor' do
    let(:line) {"minor"}
    let(:removal_strategy) {'remove_all'}

    context 'new version is newer than all existing on its line' do
      let(:dep) {{'name' => 'ruby', 'version' => '1.2.5'}}
      it 'replaces all of the named dependencies on its line' do
        expect(subject).to eq([
                                  {'name' => 'bundler', 'version' => '1.2.3'},
                                  {'name' => 'ruby', 'version' => '1.2.5'},
                                  {'name' => 'ruby', 'version' => '1.3.4'},
                                  {'name' => 'ruby', 'version' => '2.3.4'},
                                  {'name' => 'ruby', 'version' => '2.3.6'}
                              ])
      end
    end
    context 'new version is part of a new line' do
      let(:dep) {{'name' => 'ruby', 'version' => '2.4.0'}}
      it 'Maintains all old dependencies and adds the new one' do
        expect(subject).to eq(dependencies + [
            {'name' => 'ruby', 'version' => '2.4.0'}
        ])
      end
    end
    context 'new version is older than any existing on its line' do
      let(:dep) {{'name' => 'ruby', 'version' => '2.3.5'}}
      it 'returns unchanged dependencies' do
        expect(subject).to eq(dependencies)
      end
    end
  end

  context 'removal_strategy is keep_master' do
    let(:line) {'major'}
    let(:removal_strategy) {'keep_master'}
    context 'new version is newer than all existing on its line' do
      let(:dep) {{'name' => 'ruby', 'version' => '1.4.0'}}
      it 'replaces all of the named dependencies on its line keeping the latest from master' do
        expect(subject).to eq([
                                  {'name' => 'bundler', 'version' => '1.2.3'},
                                  {'name' => 'ruby', 'version' => '1.2.3'},
                                  {'name' => 'ruby', 'version' => '1.4.0'},
                                  {'name' => 'ruby', 'version' => '2.3.4'},
                                  {'name' => 'ruby', 'version' => '2.3.6'}
                              ])
      end
    end
  end

  context 'removal_strategy is keep_all' do
    let(:line) {'major'}
    let(:removal_strategy) {'keep_all'}
    context 'new version is newer than all existing on its line' do
      let(:dep) {{'name' => 'ruby', 'version' => '1.4.0'}}
      it 'replaces all of the named dependencies on its line keeping the latest from master' do
        expect(subject).to eq([
                                  {'name' => 'bundler', 'version' => '1.2.3'},
                                  {'name' => 'ruby', 'version' => '1.2.3'},
                                  {'name' => 'ruby', 'version' => '1.2.4'},
                                  {'name' => 'ruby', 'version' => '1.3.4'},
                                  {'name' => 'ruby', 'version' => '1.4.0'},
                                  {'name' => 'ruby', 'version' => '2.3.4'},
                                  {'name' => 'ruby', 'version' => '2.3.6'}
                              ])
      end
    end
  end

  # Ignore for now, until we decide how we want to handle dotnet's strange version lines
  xcontext 'when dotnet 2.1.201 already exists' do
    let(:dependencies) {[
        {'name' => 'dotnet', 'version' => '2.1.201'},
        {'name' => 'dotnet', 'version' => '2.1.300'},
        {'name' => 'dotnet', 'version' => '2.1.301'},
    ].freeze}
    let(:master_dependencies) {[
        {'name' => 'dotnet', 'version' => '2.1.201'},
        {'name' => 'dotnet', 'version' => '2.1.300'},
    ]}

    let(:line) {nil}
    let(:removal_strategy) {'keep_master'}

    let(:dep) {{'name' => 'dotnet', 'version' => '2.1.302'}}
    it 'keeps dotnet 2.1.201 when there is a new version of dotnet in the same line' do
      expect(subject).to eq([
                                {'name' => 'dotnet', 'version' => '2.1.201'},
                                {'name' => 'dotnet', 'version' => '2.1.300'},
                                {'name' => 'dotnet', 'version' => '2.1.302'},
                            ])
    end

    context 'when dotnet 2.1.201 gets rebuilt' do
      let(:dependencies) {[
          {'name' => 'dotnet', 'version' => '2.1.201', 'foo' => 'bar'},
          {'name' => 'dotnet', 'version' => '2.1.300'},
          {'name' => 'dotnet', 'version' => '2.1.301'},
      ].freeze}

      let(:dep) {{'name' => 'dotnet', 'version' => '2.1.201', 'foo' => 'baz'}}
      it 'replaces dotnet 2.1.201 with dotnet 2.1.201' do
        expect(subject).to eq([
                                  {'name' => 'dotnet', 'version' => '2.1.201', 'foo' => 'baz'},
                                  {'name' => 'dotnet', 'version' => '2.1.300'},
                                  {'name' => 'dotnet', 'version' => '2.1.301'},
                              ])
      end
    end
  end

  context 'nginx' do
    let(:master_dependencies) {[
        {'name' => 'nginx', 'version' => '1.12.0'},
        {'name' => 'nginx', 'version' => '1.13.1'},
    ]}
    let(:dependencies) {[
        {'name' => 'nginx', 'version' => '1.12.0'},
        {'name' => 'nginx', 'version' => '1.13.1'},
    ].freeze}
    let(:line) { 'nginx' }
    let(:removal_strategy) { 'remove_all' }

    context 'updating the stable line first' do
      let(:dep) {{'name' => 'nginx', 'version' => '1.14.0'}}

      it 'replaces the stable line and keeps the main line' do
        expect(subject).to eq([
                                  {'name' => 'nginx', 'version' => '1.13.1'},
                                  {'name' => 'nginx', 'version' => '1.14.0'}
                              ])
      end
    end

    context 'updating the main line first' do
      let(:dep) {{'name' => 'nginx', 'version' => '1.15.0'}}

      it 'replaces the main line and keeps the stable line' do
        expect(subject).to eq([
                                  {'name' => 'nginx', 'version' => '1.12.0'},
                                  {'name' => 'nginx', 'version' => '1.15.0'}
                              ])
      end
    end

    context 'when the main line is already up-to-date' do
      let(:dependencies) {[
          {'name' => 'nginx', 'version' => '1.12.0'},
          {'name' => 'nginx', 'version' => '1.15.0'},
      ].freeze}
      let(:dep) {{'name' => 'nginx', 'version' => '1.14.0'}}

      it 'replaces the stable line and keeps the up-to-date main line' do
        expect(subject).to eq([
                                  {'name' => 'nginx', 'version' => '1.14.0'},
                                  {'name' => 'nginx', 'version' => '1.15.0'}
                              ])
      end
    end

    context 'when the stable line is already up-to-date' do
      let(:dependencies) {[
          {'name' => 'nginx', 'version' => '1.14.0'},
          {'name' => 'nginx', 'version' => '1.13.1'},
      ].freeze}
      let(:dep) {{'name' => 'nginx', 'version' => '1.15.0'}}

      it 'replaces the main line and keeps the up-to-date stable line' do
        expect(subject).to eq([
                                  {'name' => 'nginx', 'version' => '1.14.0'},
                                  {'name' => 'nginx', 'version' => '1.15.0'}
                              ])
      end
    end

    context 'updating patch versions' do
      let(:dependencies) {[
          {'name' => 'nginx', 'version' => '1.12.0'},
          {'name' => 'nginx', 'version' => '1.13.2'},
      ].freeze}
      let(:dep) {{'name' => 'nginx', 'version' => '1.13.3'}}

      it 'replaces the patch version' do
        expect(subject).to eq([
                                  {'name' => 'nginx', 'version' => '1.12.0'},
                                  {'name' => 'nginx', 'version' => '1.13.3'}
                              ])
      end
    end
  end
end
