Class {
	#name : #BaselineOfGToolkit4Git,
	#superclass : #BaselineOf,
	#category : #BaselineOfGToolkit4Git
}

{ #category : #accessing }
BaselineOfGToolkit4Git >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		spec
			baseline: 'Brick'
			with: [ spec repository: 'github://feenkcom/Brick:main/src' ].
		spec package: 'GToolkit4Git' with: [ 
			spec requires: #( 'Brick' ) ]. ]
]
