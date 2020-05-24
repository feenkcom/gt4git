Extension { #name : #IcePackage }

{ #category : #'*GToolkit4Git' }
IcePackage >> gtActionLoadFor: anAction [
	<gtAction>
	^ anAction button
		label: 'Load';
		action: [ 
			self load.
			Iceberg announcer announce: (IceRepositoryModified for: self repository)]
]

{ #category : #'*GToolkit4Git' }
IcePackage >> gtPackageDescription [
	| description |
	description := self name asRopedText.
	self isLoaded ifFalse:[ 
		description attributes: {BlTextForegroundAttribute paint: Smalltalk ui theme disabledTextColor} ].
	self isModified ifTrue: [ 
		description := ('*', description asString) asRopedText.
		description attributes: {BlTextForegroundAttribute paint: (Color r: 0 g: 0.5 b: 0)} ].
	^ description
]

{ #category : #'*GToolkit4Git' }
IcePackage >> gtPackageStatus [
	self isLoaded ifFalse: [ 
		^ 'Not loaded' asRopedText
				attributes: {BlTextForegroundAttribute paint: Smalltalk ui theme disabledTextColor};
				yourself ].
	self isModified ifTrue: [ ^ 'Uncommited changes' asRopedText ].
	^ 'Up to date' asRopedText
]
