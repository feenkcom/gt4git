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
			baseline: 'Brick'
			with: [ spec repository: 'github://feenkcom/Brick:main/src' ].
		spec
			baseline: 'IcebergGitCli'
			with: [ spec repository: 'github://feenkcom/iceberg-git-cli:main/src' ].
		spec package: 'GToolkit4Git' with: [ 
			spec requires: #( 'Brick' 'IcebergGitCli') ]. ]
]
