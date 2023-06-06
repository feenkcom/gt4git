Class {
	#name : #GtIceCheckoutAllPackages,
	#superclass : #IceCheckoutAllPackages,
	#instVars : [
		'lepiterWorkingCopy'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtIceCheckoutAllPackages class >> isGtStrategy [
	^ true
]

{ #category : #accessing }
GtIceCheckoutAllPackages >> checkoutOn: anIceWorkingCopy [
	"Calling super performs a forced checkout. After this updates files from disk, trigger a reload of lepiter databases affected by this change."

	super checkoutOn: anIceWorkingCopy.
	lepiterWorkingCopy ifNil: [ ^ self ].
	lepiterWorkingCopy loadLepiterChangesInWorkingCopyFrom: self diff
]

{ #category : #accessing }
GtIceCheckoutAllPackages >> lepiterWorkingCopy: aLepiterWorkingCopy [
	lepiterWorkingCopy := aLepiterWorkingCopy
]
