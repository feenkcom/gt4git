Extension { #name : #HiLink }

{ #category : #'*GToolkit4Git' }
HiLink >> pointString [
	^ String
		streamContents: [ :s | 
			s nextPutAll: origin rulerPoint printString , '->'.
			"intermediatePoints do: [ :each | s nextPutAll: each printString , '->' ]."
			s nextPutAll: target rulerPoint printString ]
]
