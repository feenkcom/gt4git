Class {
	#name : #BaselineOfGToolkit4Git,
	#superclass : #BaselineOf,
	#category : #BaselineOfGToolkit4Git
}

{ #category : #baseline }
BaselineOfGToolkit4Git >> baseline: spec [
	<baseline>
	spec for: #'common' do: [
		spec
			baseline: 'Brick' with: [
				spec repository: 'github://feenkcom/Brick:v0.8.1414/src' ].
		spec
			baseline: 'IcebergGitCli' with: [
				spec repository: 'github://feenkcom/iceberg-git-cli:v0.6.122/src' ].

		spec package: 'GToolkit4Git' with: [
			spec requires: #(#Brick #IcebergGitCli) ].
	]
]
