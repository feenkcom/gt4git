Extension { #name : #PureGitBlob }

{ #category : #'*GToolkit4Git' }
PureGitBlob >> gtImageFor: composite [
	<gtView>
	| bytes |
	bytes := self contents.
	(self class imageTypeUsingMagicHeaderFrom: bytes)
		ifNil: [ ^ composite empty ].
	^ composite explicit
		title: 'Image';
		priority: 40;
		stencil: [ 
			(ImageReadWriter gtFormFromBuffer: bytes) asElement
				margin: (BlInsets all: 10) ]
]

{ #category : #'*GToolkit4Git' }
PureGitBlob >> gtTextFor: composite [
	<gtView>
	| text |
	[ text := self contents utf8Decoded ] 
		on: ZnCharacterEncodingError 
		do: [ ^ composite empty ].
	^ composite textEditor
		title: 'Text';
		priority: 40;
		glamorousCodeFontAndSize;
		text: [ text ]
]
