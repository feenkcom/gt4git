Class {
	#name : #GtIceCheckoutDoNotLoadPackages,
	#superclass : #IceCheckoutDoNotLoadPackages,
	#instVars : [
		'lepiterWorkingCopy'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtIceCheckoutDoNotLoadPackages class >> isGtStrategy [
	^ true
]

{ #category : #accessing }
GtIceCheckoutDoNotLoadPackages >> checkoutOn: anIceWorkingCopy [ 
	"Calling super performs a forced checkout. After this updates files from disk, trigger a reload of lepiter databases affected by this change."
	
	super checkoutOn: anIceWorkingCopy.
	lepiterWorkingCopy ifNil: [ ^ self ].
	lepiterWorkingCopy loadLepiterChangesInWorkingCopyFrom: self diff.
]

{ #category : #accessing }
GtIceCheckoutDoNotLoadPackages >> lepiterWorkingCopy: aLepiterWorkingCopy [
	lepiterWorkingCopy := aLepiterWorkingCopy
]
