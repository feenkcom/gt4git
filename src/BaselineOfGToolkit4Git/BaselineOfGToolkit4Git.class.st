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
				spec repository: 'github://feenkcom/Brick:v0.8.588/src' ].

		spec package: 'GToolkit4Git' with: [
			spec requires: #('Brick') ].
	]
]
