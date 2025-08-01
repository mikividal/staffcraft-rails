import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log(" Stimulus: connect() started")
    this.currentStep = 1
    this.totalSteps = 5

    this.initializeValidation()
    this.initializeConditionalFields()
    this.initializeAutoSave()
    this.loadSavedData()
    this.bindStepClicks()
    this.bindKeyboardNavigation()
    this.bindFormSubmit()
    this.injectShakeCSS()

    console.log("✅ Stimulus: analysis controller connected")
  }

  showSection(event) {
    const sectionNumber = parseInt(event.target.dataset.sectionNumberValue)

    if (sectionNumber > this.currentStep && !this.validateSection(this.currentStep)) {
      return
    }

    // Hide all sections
    document.querySelectorAll('.form-section').forEach(section => {
      section.classList.add('d-none')
    })

    // Show target section with animation
    const targetSection = document.getElementById(`section-${sectionNumber}`)
    if (targetSection) {
      setTimeout(() => {
        targetSection.classList.remove('d-none')
      }, 100)
    }

    this.currentStep = sectionNumber
    this.updateStepIndicators()
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  updateStepIndicators() {
    document.querySelectorAll('.step').forEach((step, index) => {
      const stepNumber = index + 1
      step.classList.remove('active', 'completed')

      if (stepNumber === this.currentStep) {
        step.classList.add('active')
      } else if (stepNumber < this.currentStep) {
        step.classList.add('completed')
      }
    })
  }

  toggleOtherField(event) {

    const selectElement = event.target
    const targetId = selectElement.dataset.toggleTarget
    const targetGroup = document.getElementById(targetId)


    if (!targetGroup) return

    const inputField = targetGroup.querySelector('input')

    if (selectElement.value.includes('other')) {
      targetGroup.style.display = 'block'
      targetGroup.classList.add('show')
      if (inputField) setTimeout(() => inputField.focus(), 300)
    } else {
      targetGroup.classList.remove('show')
      setTimeout(() => {
        targetGroup.style.display = 'none'
        if (inputField) inputField.value = ''
      }, 300)
    }
  }

  validateSection(sectionNumber) {
    const section = document.getElementById(`section-${sectionNumber}`)
    const requiredFields = section.querySelectorAll('[required]')
    let isValid = true

    requiredFields.forEach(field => {
      if (!field.value.trim()) {
        this.showFieldError(field, 'This field is required')
        field.classList.add('is-invalid')
        field.classList.remove('is-valid')
        isValid = false
      } else {
        this.hideFieldError(field)
        field.classList.remove('is-invalid')
        field.classList.add('is-valid')
      }
    })

    const urlFields = section.querySelectorAll('input[type="url"]')
    urlFields.forEach(field => {
      if (field.value && !this.isValidURL(field.value)) {
        this.showFieldError(field, 'Please enter a valid URL')
        field.classList.add('is-invalid')
        field.classList.remove('is-valid')
        isValid = false
      }
    })

    if (!isValid) {
      section.style.animation = 'shake 0.5s ease-in-out'
      setTimeout(() => {
        section.style.animation = ''
      }, 500)
    }

    return isValid
  }

  showFieldError(field, message) {
    this.hideFieldError(field)
    const errorDiv = document.createElement('div')
    errorDiv.className = 'field-error text-danger small mt-1'
    errorDiv.textContent = message
    field.parentElement.appendChild(errorDiv)
  }

  hideFieldError(field) {
    const errorDiv = field.parentElement.querySelector('.field-error')
    if (errorDiv) errorDiv.remove()
  }

  isValidURL(string) {
    try {
      new URL(string)
      return true
    } catch (_) {
      return false
    }
  }

  initializeValidation() {
    document.querySelectorAll('input, select, textarea').forEach(field => {
      field.addEventListener('blur', () => {
        if (field.hasAttribute('required') && !field.value.trim()) {
          this.showFieldError(field, 'This field is required')
          field.classList.add('is-invalid')
          field.classList.remove('is-valid')
        } else if (field.value.trim()) {
          this.hideFieldError(field)
          field.classList.remove('is-invalid')
          field.classList.add('is-valid')
        }

        if (field.type === 'url' && field.value && !this.isValidURL(field.value)) {
          this.showFieldError(field, 'Please enter a valid URL')
          field.classList.add('is-invalid')
          field.classList.remove('is-valid')
        }
      })

      field.addEventListener('input', () => {
        if (field.classList.contains('is-invalid') && field.value.trim()) {
          this.hideFieldError(field)
          field.classList.remove('is-invalid')
          field.classList.add('is-valid')
        }
      })
    })
  }

  initializeConditionalFields() {
    // already handled inline via onchange
  }

  initializeAutoSave() {
    let autoSaveTimeout

    document.querySelectorAll('input, select, textarea').forEach(field => {
      field.addEventListener('input', () => {
        clearTimeout(autoSaveTimeout)
        autoSaveTimeout = setTimeout(() => {
          this.saveFormData()
        }, 2000)
      })
    })
  }

  saveFormData() {
    try {
      const formData = new FormData(document.getElementById('staffcraft-form'))
      const dataObject = {}

      for (let [key, value] of formData.entries()) {
        dataObject[key] = value
      }

      localStorage.setItem('staffcraft_draft', JSON.stringify(dataObject))
      this.showSaveIndicator()
    } catch (e) {
      console.log('Could not save form data')
    }
  }

  showSaveIndicator() {
    const existing = document.querySelector('.save-indicator')
    if (existing) existing.remove()

    const indicator = document.createElement('div')
    indicator.className = 'save-indicator position-fixed top-0 end-0 m-3 alert alert-success alert-dismissible fade show'
    indicator.style.zIndex = '9999'
    indicator.innerHTML = `
      <svg class="checkmark me-2" viewBox="0 0 24 24" width="20" height="20" stroke="currentColor" fill="none">
        <path d="M20 6L9 17l-5-5"/>
      </svg>
      Draft saved automatically
    `

    document.body.appendChild(indicator)

    setTimeout(() => {
      if (indicator.parentNode) {
        indicator.remove()
      }
    }, 3000)
  }

  loadSavedData() {
    try {
      const savedData = localStorage.getItem('staffcraft_draft')
      if (savedData) {
        const data = JSON.parse(savedData)
        Object.keys(data).forEach(key => {
          const field = document.querySelector(`[name="${key}"]`)
          if (field && !field.value) {
            field.value = data[key]
          }
        })
      }
    } catch (e) {
      console.log('Could not load saved data')
    }
  }

  bindStepClicks() {
    document.querySelectorAll('.step').forEach((step, index) => {
      step.addEventListener('click', () => {
        const stepNumber = index + 1
        if (stepNumber <= this.currentStep || this.validateAllPreviousSections(stepNumber)) {
          this.showSection(stepNumber)
        }
      })
    })
  }

  validateAllPreviousSections(targetStep) {
    for (let i = 1; i < targetStep; i++) {
      if (!this.validateSection(i)) {
        return false
      }
    }
    return true
  }

  bindKeyboardNavigation() {
    document.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowRight' && this.currentStep < this.totalSteps) {
        if (this.validateSection(this.currentStep)) {
          this.showSection(this.currentStep + 1)
        }
      } else if (e.key === 'ArrowLeft' && this.currentStep > 1) {
        this.showSection(this.currentStep - 1)
      }
    })
  }

  bindFormSubmit() {
    const form = document.getElementById('staffcraft-form')
    if (!form) return

    form.addEventListener('submit', (e) => {
      let allValid = true
      for (let i = 1; i <= this.totalSteps; i++) {
        if (!this.validateSection(i)) {
          allValid = false
          this.showSection(i)
          break
        }
      }

      if (!allValid) {
        e.preventDefault()
        return
      }

      const submitButton = document.getElementById('submit-button')
      if (submitButton) {
        submitButton.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Processing Analysis...'
        submitButton.classList.add('loading')
      }

      localStorage.removeItem('staffcraft_draft')
    })
  }

  injectShakeCSS() {
    const style = document.createElement('style')
    style.textContent = `
      @keyframes shake {
        0%, 100% { transform: translateX(0); }
        10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
        20%, 40%, 60%, 80% { transform: translateX(5px); }
      }
    `
    document.head.appendChild(style)
  }
}
