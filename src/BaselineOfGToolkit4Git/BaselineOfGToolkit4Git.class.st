Class {
	#name : #BaselineOfGToolkit4Git,
	#superclass : #BaselineOf,
	#category : #BaselineOfGToolkit4Git
}

{ #category : #accessing }
BaselineOfGToolkit4Git >> baseline: spec [
	<baseline>
	spec
		for: #common do: [
			spec
				package: 'GToolkit4Git' ]
]
