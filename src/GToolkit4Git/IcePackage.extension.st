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
IcePackage >> gtCoderFor: aView [
	<gtView>
	self isLoaded ifFalse: [ 
		"Ideally this would show a view of the package on disk"
		^ aView empty ].
	^ aView explicit
		title: 'Coder';
		stencil: [(GtCoder forPackage: (self name asPackage)) beDetailedTool ]
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
	|label|
	self isLoaded ifFalse: [
		| loadButton|
		loadButton := BrButton new.
		loadButton look: (BrGlamorousButtonRectangularLook + BrGlamorousButtonExteriorLook + 
			(BrGlamorousButtonLabelLook new selectedColor: Color black)).
		loadButton label: 'Load'.
		loadButton action: [ self load].
		^ loadButton].
		"^ 'Not loaded' asRopedText
				attributes: {BlTextForegroundAttribute paint: Smalltalk ui theme disabledTextColor};
				yourself ]."
	label := BrLabel new.
	label look: BrGlamorousLabelLook.
	self isModified ifTrue: [ 
		label text: 'Uncommited changes'].
	label text: 'Up to date'.
	^  label
]
